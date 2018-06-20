module HelperMethods
  def encryptor
    ActiveSupport::MessageEncryptor.new Rails.application.credentials[:secret_key_base][0, 32], Rails.application.credentials[:secret_key_base]
  end

  def encrypt(value)
    encryptor.encrypt_and_sign Marshal.dump(value)
  end

  def redis
    $redis ||= Redis.new
  end
end