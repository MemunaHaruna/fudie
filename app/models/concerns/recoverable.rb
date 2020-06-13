module Recoverable
  def soft_destroy
    self.update!(deleted_at: Time.now)
  end

  def recover
    self.update!(deleted_at: nil)
  end

  def destroy_fully
    self.destroy if self.deleted_at <= 4.weeks.ago

    # < == older than (a < b means a comes before b)
    # > == earlier than (a > b means a comes after b)
  end
end

