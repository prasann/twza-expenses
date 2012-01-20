EXPENSE_SHEET_DATE_FORMAT = '%d/%m/%Y'

namespace :db do
  namespace :fixtures do

    TEST_CURRENCIES = ['USD', 'GBP']
    CURRENCY_RATES = [48, 83]
    OFFICES = ['Bangalore', 'Chennai']
    COUNTRIES = ['US', 'UK']

    task :setup_env do
      Rails.env = 'development'
    end

    desc 'Create sample test data for the development environment for profile, expenses, forex and travel'
    task :create, [:user_name, :emp_id, :email_id] => [:setup_env, :environment] do |t, args|

      user_name = args[:user_name]
      employee_id = args[:emp_id]
      email_id = args[:email_id]

      travel_start_date = generate_random_date()
      possible_end_dates = [generate_random_date_between(travel_start_date), Time.now]
      travel_end_date = possible_end_dates[rand(possible_end_dates.length)]

      currency_index = rand(TEST_CURRENCIES.length)
      currency = TEST_CURRENCIES[currency_index]

      insert_profile(user_name, employee_id, email_id)

      base_currency_rate = CURRENCY_RATES[currency_index]
      currency_rate = rand(base_currency_rate .. base_currency_rate+5)
      place_of_visit = COUNTRIES[currency_index]
      insert_forex(employee_id, user_name, travel_start_date, travel_end_date, currency, currency_rate, place_of_visit)

      insert_travel(employee_id, user_name, travel_start_date, travel_end_date,place_of_visit)

      insert_expenses(employee_id, user_name, travel_start_date, travel_end_date, currency,currency_rate)
    end

    def generate_random_date(years_back=1, month=nil, day=nil)
      year = Time.now.year - rand(years_back) - 1
      month = month ? month: (rand(12) + 1)
      day = day ? day: (rand(31) + 1)
      travel_date = Time.local(year, month, day)
    end

    def generate_random_date_between(start_date, end_date=Time.local(2011, 12, 31))
      if (!start_date.instance_of? Time || !end_date.instance_of?(Time))
        return generate_random_date()
      end
      Time.at(start_date + rand * (end_date.to_f - start_date.to_f))
    end

    def insert_profile(user_name, employee_id, email_id)
      matchingProfiles = Profile.find_by_employee_id employee_id
      if !matchingProfiles.nil?
        return
      end
      sql = "insert into profiles(name, common_name, employee_id, email_id) "+
          "values ('#{user_name}', '#{user_name}', #{employee_id}, '#{email_id}')"
      ActiveRecord::Base.establish_connection()
      ActiveRecord::Base.connection.execute(sql)
    end

    def insert_forex(employee_id, user_name, travel_start_date, travel_end_date, currency, currency_rate, place_of_visit)
      start_date = travel_start_date

      rand(1..5).times.each do
        amount = rand(1000 .. 2500)
        ForexPayment.create(
            :emp_id => employee_id, :emp_name => user_name,
            :amount => amount,
            :currency => currency,
            :travel_date => travel_start_date, :office => OFFICES[rand(OFFICES.length)],
            :issue_date => start_date,
            :place => place_of_visit,
            :inr => currency_rate * amount
        )
        start_date = generate_random_date_between(start_date, travel_end_date)
      end
    end

    def insert_travel(employee_id, user_name, travel_start_date, travel_end_date,place_of_visit)
      OutboundTravel.create(
          :emp_id => employee_id, :emp_name => user_name,
          :departure_date => travel_start_date,
          :return_date => travel_end_date,
          :place => place_of_visit
      )
    end

    def insert_expenses(employee_id, user_name, travel_start_date, travel_end_date, currency,currency_rate)
      start_date = travel_start_date
      expense_types = ['Personal Cash or check', 'Per diem', 'Hotel']
      rand(1..10).times.each do
        original_cost = rand(10..10000)
        expense_date = generate_random_date_between(start_date, travel_end_date)
        expense = Expense.create(
            :empl_id => 'EMP'+employee_id, :name => user_name,
            :expense_rpt_id => rand(100000..900000),
            :cost_in_home_currency => original_cost * currency_rate,
            :expense_date => expense_date.strftime(EXPENSE_SHEET_DATE_FORMAT),
            :expense_type => expense_types[rand(expense_types.length)],
            :original_cost => original_cost,
            :original_currency => currency,
            :report_submitted_date => expense_date.strftime(EXPENSE_SHEET_DATE_FORMAT)
        )
        start_date = generate_random_date_between(start_date, travel_end_date)
      end
    end
  end
end