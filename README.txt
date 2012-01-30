This software automates some aspects of interaction with the Warwickshire (UK) public library system. It generally accepts a user barcode and PIN as input, and carries out functions such as extracting a list of current loans, or renewing items when they become due.

It is written in Ruby, and can be deployed on Heroku.

Currently it supports two actions:
Loans:
Retrieves list of current loans on an account
Call using GET http://host/loans/:name/:bc/:pin where
:name = an arbitrary identifier to use for the account
:bc = a valid user barcode
:pin = a valid user pin, corresponding to the barcode

Renew:
Renews items on a given account that are due on the current date. Items cannot always be renewed due to system restrictions (e.g. maximum of three renewals for each item; reserved by other users), and these will not be renewed.
Call using GET http://host/renew/:name/:bc/:pin where
:name = an arbitrary identifier to use for the account
:bc = a valid user barcode
:pin = a valid user pin, corresponding to the barcode