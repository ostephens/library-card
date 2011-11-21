require 'rubygems'
require 'sinatra'
require './lib/librarysystems'
require './lib/account'

warks = Warks.new()
damyanti = Account.new('4336855X','18011976','patel.damyanti@gmail.com',warks)
owen = Account.new('4356489X','19041972','owen.patel@gmail.com',warks)

get '/go-go-owen-renew' do
    owen.getLoans
    owen.renewLoans
    output = owen.currentloans.printLoanlist
end

#get '/go-go-damyanti-renew' do
#    damayanti.getCurrentloans
#    damyanti.renewLoans
#    "#{damyanti.currentloans.to_s}"
#end