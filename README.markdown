# SQS Mailer

A loop to send email messages sent to an Amazon SQS queue.

## Dependencies

1. right_aws -

                sudo gem install right_aws

2. json -

                sudo gem install json

3. An Amazon SQS account & queue

## Setup

1. Update accounts.yml with your own Amazon account data.

2. Update accounts.yml with your SMTP data

## Run

ruby ./mailer.rb

## Message Format

The mailer expects that JSON messages will be sent to the queue with this format / data:

    {
      "identifier": "mysupersecretidentifier",
      "to": "someone@somewhere.com",
      "from": "me@here.com",
      "subject": "Title Goes Here",
      "body": "Captivating, I'm sure"
    }

## Disclaimer

This does not handle failure scenarios with any grace whatsoever.  In fact, it will probably lose whatever email it pukes on and then just die without even saying "sorry".
