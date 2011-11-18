require 'rubygems' 
require 'sinatra'

get '/' do 
    html = '<p>Welcome! Leave your email address for more info!</p>' 
    html += '<form method="post" action="/submit">' 
    html += '<input type="text" name="email" /><input type="submit" /></form>' 
    return html
end

post '/submit' do 
    html = '<p>Thank you for your submission!</p>' 
    html += '<p>We will email ' + params['email'] 
    html += ' when we are ready to launch!</p>' 
    return html
end