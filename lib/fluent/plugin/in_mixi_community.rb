require 'fluent/plugin'
require 'fluent/config'
require 'fluent/input'

1.tap do
  # https://github.com/fluent/fluentd/issues/76
  encoding = Encoding.default_internal
  Encoding.default_internal = nil
  require 'mime/types'
  Encoding.default_internal = encoding
end

require 'mixi-community'
require 'pit'

class Fluent::MixiCommunityInput < Fluent::Input
  Fluent::Plugin.register_input('mixi_community', self)

  config_param :interval_sec, :integer
  config_param :pit_id, :string
  config_param :community_id, :integer
  config_param :thread_title_pattern, :string
  config_param :recent_threads_num, :integer
  config_param :tag, :string

  def configure(config)
    super
    @thread_title_pattern = Regexp.new(@thread_title_pattern, {}, 'n')

    user_info = Pit.get(@pit_id, require: {
      'email' => 'mail',
      'password' => 'password',
    })
    @fetcher = Mixi::Community::Fetcher.new(
      user_info['email'],
      user_info['password']
    )
    @community = Mixi::Community.new(@community_id)
    # {[community_id, bbs_id] => last_comment_id}
    @last_comment_ids = {}
  end

  def start
    @thread = Thread.new(&method(:run))
  end

  def shutdown
    @thread.kill
  end

  def run
    loop do
      fetch_and_emit
      sleep @interval_sec
    end
  end

  def fetch_and_emit
    @community.fetch(@fetcher)
    @community.recent_bbses[0...@recent_threads_num].select{|th| th.title =~ @thread_title_pattern}.each do|th|
      sleep 1
      th.fetch(@fetcher)
      th.recent_comments.each do|comment|
        last_comment_id = @last_comment_ids[[@community.id, th.id]]
        next if last_comment_id && comment.id <= last_comment_id
        @last_comment_ids[[@community.id, th.id]] = comment.id

        Fluent::Engine.emit(@tag, Fluent::Engine.now, {
          'community' => {
            'id' => @community.id,
          },
          'thread' => {
            'id' => th.id,
            'title' => th.title,
          },
          'comment' => {
            'id' => comment.id,
            'num' => comment.num,
            'user_name' => comment.user_name,
            'body_text' => comment.body_text,
          }
        })
      end
    end
  end
end
