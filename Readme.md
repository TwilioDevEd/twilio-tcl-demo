# Twilio Messaging Example (Tcl/Tk)

An example application that demonstrates how to send SMS text messages using Tcl and Tk.  Requires the tls package.

Please read [our full article](https://www.twilio.com/docs/guides/send-sms-and-mms-messages-tcl-tk) for more information.

## Download example:

<pre>
git clone https://github.com/TwilioDevEd/twilio-tcl-demo.git
cd twilio-tcl-demo
</pre>

## Run example:

(Example is in bash; your shell may differ.  With a Windows distribution, _.tcl_ files should become executable, but you will need to set the environment variables)

You must have a [Twilio account](https://twilio.com) to run this example.

Account SID and the Auth Token can be found in your Twilio console.  Change the from number to a number in your [Twilio Account](https://twilio.com/console).

Note that depending on how your Tcl was installed, you may not have some packages.  This example requires:
* http
* tls
* base64
* ttk (Built into Tcl 8.5+)

An [ActiveTcl](http://www.activestate.com/activetcl) distribution for your platform might be the fastest way for you to get what is required through their Teacup package manager.  Ex:
<pre>
    
</pre>



Alternatively, you may build from source.

<pre>
export TWILIO_ACCOUNT_SID=ACXXXXXXXXXXX
export TWILIO_AUTH_TOKEN=yourauthtokengoeshere
export TWILIO_PHONE_NUMBER=+18005551212
chmod 755 twilio.tcl
./twilio.tcl
</pre>

## Motivations

Hopefully you can use this as a base for a larger project, or incorporate it into your existing projects.

## Meta & Licensing

* [MIT License](http://www.opensource.org/licenses/mit-license.html)
* Lovingly crafted by Twilio Developer Education.