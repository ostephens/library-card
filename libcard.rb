require 'rubygems'
require 'sinatra'
require './lib/librarysystems'
require './lib/account'

helpers do
    def loans
        warks = Warks.new()
        damyanti = Account.new('4336855X','18011976','patel.damyanti@gmail.com',warks)
        owen = Account.new('4356489X','19041972','owen.patel@gmail.com',warks)
        owen.getLoans
        owen.renewLoans
        output = owen.printLoans
        return output
  end
end

get '/' do
    code = "<%= Time.now %>"
    erb code
end

get '/go-go-owen-renew' do
    loans
end

#get '/go-go-damyanti-renew' do
#    damayanti.getCurrentloans
#    damyanti.renewLoans
#    "#{damyanti.currentloans.to_s}"
#end
