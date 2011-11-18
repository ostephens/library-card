require 'rubygems'
require 'sinatra'
require 'lib/librarysystems'
#require 'lib/account'

#warks = Vubis.new('warks','https://library.warwickshire.gov.uk/vs/Pa.csp?OpacLanguage=eng&Profile=Default')
#damyanti = Account.new('4336855X','18011976','patel.damyanti@gmail.com',warks)
#owen = Account.new('4356489X','19041972','owen.patel@gmail.com',warks)

get '/go-go-owen-renew' do
#    owen.getCurrentloans
#    owen.renewLoans
#    owen.getCurrentloans
#    "#{owen.currentloans.to_s}"
    "done"
end