#!/usr/bin/ruby
#Main
require 'libcard/librarysystems'
require 'libcard/account'

warks = Vubis.new('warks','https://library.warwickshire.gov.uk/vs/Pa.csp?OpacLanguage=eng&Profile=Default')
damyanti = Account.new('4336855X','18011976','patel.damyanti@gmail.com',warks)
owen = Account.new('4356489X','19041972','owen.patel@gmail.com',warks)

owen.getCurrentloans
puts owen.currentloans.to_s
owen.renewLoans

if owen.currentloans.length > 0
#    loans.send_email("owen.patel@gmail.com", "owenfrom", owen.email,"owento")
end