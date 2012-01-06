class CreateProfiles < ActiveRecord::Migration

  def self.up

create_table "profiles", :force => true do |t|
  t.string "name"
  t.string "surname"
  t.string "common_name"
  t.string "title"
  t.string "gender"
  t.string "marital_status"
  t.string "permanent_address_line_1"
  t.string "permanent_address_line2"
  t.string "permanent_address_line3"
  t.string "permanent_city"
  t.string "permanent_state"
  t.string "permanent_pincode"
  t.string "temporary_address_line1"
  t.string "temporary_address_line2"
  t.string "temporary_address_line3"
  t.string "temporary_city"
  t.string "temporary_state"
  t.string "temporary_pincode"
  t.string "guardian_name"
  t.string "location"
  t.date "date_of_joining"
  t.datetime "created_at"
  t.datetime "updated_at"
  t.date "transfer_date"
  t.string "transfer_from"
  t.string "transfer_to"
  t.string "employee_id"
  t.date "date_of_birth"
  t.date "last_day"
  t.string "transferred_abroad"
  t.boolean "completed"
  t.integer "years_of_experience"
  t.string "email_id"
  t.string "permanent_phone_number"
  t.string "temporary_phone_number"
  t.string "personal_email_id"
  t.string "account_no"
  t.string "pan_no"
  t.string "epf_no"
  t.string "type"
  t.string "emergency_contact_person"
  t.string "emergency_contact_number"
  t.string "blood_group"
  t.string "access_card_number"
end

  end

  def self.down
    drop_table 'profiles'
  end
end
