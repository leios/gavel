ANNOTATOR_ID = 'annotator_id'
TELEMETRY_URL = 'https://telemetry.anish.io/api/v1/submit'
TELEMETRY_DELTA = 20 * 60 # seconds
SENDGRID_URL = "https://api.sendgrid.com/v3/mail/send"

# Setting
# keys
SETTING_CLOSED = 'closed' # boolean
SETTING_TELEMETRY_LAST_SENT = 'telemetry_sent_time' # integer
# values
SETTING_TRUE = 'true'
SETTING_FALSE = 'false'

# Defaults
# these can be overridden via the config file
DEFAULT_WELCOME_MESSAGE = '''
Welcome to Gavel.

**Please read this important message carefully before continuing.**

Gavel is a fully automated expo judging system that both tells you where to go
and collects your votes.
We are using this for the Summer of Math Exposition (SoME1) because it seems to be a well-tested and rigorous system to find winners in hack-a-thon settings.

As an important note: we fully recognize that SoME1 is not a hack-a-thon.
This system will only be used to find the top 100 applicants.
Those applications will then be manually judged by Grant Sanderson, James Schloss, and other certified judges.

The system is based on the model of pairwise comparison. You'll start off by
looking at a single submission, and then for every submission after that,
you'll decide whether it's better or worse than the one you looked at
**immediately beforehand**.

If at any point, you do not feel qualified to judge a particular submission, you can click the
'Skip' button and you will be assigned a new project.
If there is a project that is improperly formatted or does not have an appropriate link, please e-mail jrs.schloss@gmail.com.
 **Please don't skip unless absolutely necessary.**

Gavel makes it really simple for you to submit votes, but please think hard
before you vote. **Once you make a decision, you can't take it back**.

For other questions, please contact jrs.schloss@gmail.com
'''.strip()

DEFAULT_EMAIL_SUBJECT = 'Welcome to Gavel!'

DEFAULT_EMAIL_BODY = '''
Hello!

Welcome to Gavel, the online expo judging system that will be used for the Summer of Math Exposition (SoME1) competition. This email contains your
magic link to the judging system.

DO NOT SHARE this email with others, as it contains your personal magic link.

To access the system, visit {link}.

Once you're in, please take the time to read the welcome message and
instructions before continuing.
'''.strip()

DEFAULT_CLOSED_MESSAGE = '''
The judging system is currently closed. Reload the page to try again.
'''.strip()

DEFAULT_DISABLED_MESSAGE = '''
Your account is currently disabled. Reload the page to try again.
'''.strip()

DEFAULT_LOGGED_OUT_MESSAGE = '''
You are currently logged out. Open your magic link to get started.
'''.strip()

DEFAULT_WAIT_MESSAGE = '''
Wait for a little bit and reload the page to try again.

If you've looked at all the projects already, then you're done.
'''.strip()
