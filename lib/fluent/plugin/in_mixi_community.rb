require 'mixi-community'
require 'pit'

class Fluent::MixiCommunityInput < Fluent::Input
  Fluent::Plugin.register_output('mixi_community', self)

  config_param :interval_sec, :integer
  config_param :pit_id, :string
  config_param :community_id, :integer
  config_param :title_pattern, :string
  config_param :tag, :string

  def configure(config)
    super
    @title_pattern = Regexp.new(@title_pattern)

    user_info = Pit.get(@pit_id, require: {
      'email' => 'mail',
      'password' => 'password',
    })
    @fetcher = Mixi::Community::Fetcher.new(
      user_info['email'],
      user_info['password']
    )
    @community = Mixi::Community.new(@community_id)
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
    @community.recent_bbses.select{|th| th.title =~ @title_pattern}.each do|th|
      th.fetch(@fetcher)
      th.recent_comments.each do|comment|
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
