FactoryBot.define do
  factory :admin_audit_log do
    admin { nil }
    target_user { nil }
    action { "MyString" }
    ip_address { "MyString" }
    user_agent { "MyText" }
    target_type { "MyString" }
    notes { "MyText" }
  end
end
