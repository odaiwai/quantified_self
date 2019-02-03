#!/usr/bin/ruby
require 'rubygems'
require 'mechanize'

class Fitbit

  def initialize(email, pass)
    @email = email
    @pass = pass
    @mechanize = Mechanize.new
  end

  def login
    page = @mechanize.get('https://www.fitbit.com/login')
    form = page.forms.first
    form.email = @email
    form.password = @pass
    page = @mechanize.submit(form, form.buttons.first)
  end

  def data(date = Time.now)
    login

    page = @mechanize.get "https://www.fitbit.com/#{date.strftime("%Y-%m-%d").gsub('-','/')}"

    data = {
      :bed_time => page.search("//ul[@id='sleepSummary']").search("span").children[1].text.strip,
      :times_awakened => page.search("//ul[@id='sleepSummary']").search("span").children[5].text,
      :bed_duration => page.search("//ul[@id='sleepSummary']").search("span").children[7].text,
      :sleep_duration => page.search("//ul[@id='sleepSummary']").search("span").children[9].text,
      :sleep_efficiency => page.search("//div[@id='sleepIndicator']").search("span").children[1].text
    }
    data
  end

end
