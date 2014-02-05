# Google's captcha for displaying an email address.
# http://www.google.com/recaptcha/mailhide/
# http://github.com/pilaf/recaptcha-mailhide
RecaptchaMailhide.configure do |c|
  c.private_key = ENV['RECAPTCHA_MAILHIDE_PRIVATE_KEY'].presence || 'c5e309c2cf3073efa67445e0d1151519'
  c.public_key  = ENV['RECAPTCHA_MAILHIDE_PUBLIC_KEY'].presence || '01fK6Ztpuesudadb10f1IppQ=='
end
