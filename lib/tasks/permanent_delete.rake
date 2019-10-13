desc "cron task to permanently delete archived records."

task permanent_delete: :environment do
  begin
    # TO-DO: schedule this job with Heroku Scheduler
    Post.only_soft_deleted.each{|post| post.destroy_fully }
    User.only_soft_deleted.each{|user| user.destroy_fully }
  rescue => e
    Rails.logger.error(e)
  end
end
