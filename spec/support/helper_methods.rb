module HelperMethods
  def encryptor
    ActiveSupport::MessageEncryptor.new Rails.application.credentials[:secret_key_base]
  end

  def encrypt(value)
    encryptor.encrypt_and_sign Marshal.dump(value)
  end
  
  def decrypt(value)
    Marshal.load encryptor.decrypt_and_verify(value)
  end
end