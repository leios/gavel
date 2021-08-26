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

Gavel is a fully automated expo judging system that both provides links
and collects your votes.
We are using this for the Summer of Math Exposition (SoME1) because it seems to be a well-tested and rigorous system to find winners in hack-a-thon settings.

As an important note: we fully recognize that SoME1 is not a hack-a-thon.
This system will only be used to find the top 100 applicants.
Those applications will then be manually judged by Grant Sanderson, James Schloss, and other certified judges.

The system is based on the model of pairwise comparison. You'll start off by
looking at a single submission, and then for every submission after that,
you'll decide whether it's better or worse than the one you looked at
**immediately beforehand**.
This means that the previous and current entries are intended to continually cycle out unless you choose to skip.

Please also use the <a href="https://docs.google.com/forms/d/e/1FAIpQLSc02JOlg0aAim5EukRlziSUdP59v40rgHizyW2PjNl-snfSTg/viewform?usp=sf_link">SoME1 Specific Feedback Form</a> whenever you feel it's necessary to provide more precise feedback.

If at any point, you do not feel qualified to judge a particular submission, you can click the
'Skip' button and you will be assigned a new project.
If there is a project that is improperly formatted or does not have an appropriate link, please e-mail jrs.schloss@gmail.com.
 **Please don't skip unless absolutely necessary.**

Gavel makes it really simple for you to submit votes, but please think hard
before you vote. **Once you make a decision, you can't take it back**.
If you go back in your browser, you should not find previous entries, but instead the entries you are expected to be voting on next.

For other questions, please contact jrs.schloss@gmail.com

Thanks again for your willingness to participate in the Summer of Math Exposition!
We are really excited to learn from everyone in the coming week!

For specific questions, please checkout out the <a href="https://github.com/leios/gavel/wiki/Frequently-Asked-Questions">FAQ</a> or <a href="https://discord.gg/Vkf29b5s">Discord</a>.
if you cannot find your answers there, please contact Dr. James Schloss at jrs.schloss@gmail.com

<b>Judging Criteria</b>

<p> 
<b>Please look at at least 5 entries by Wednesday, September 1st!</b>

As discussed on the <a href="https://www.3blue1brown.com/blog/some1">SoME1 Website</a> please consider the following criteria when judging each entry:

<ol>
<li><b>Clarity</b>: Jargon should be explained, the goals of the lesson should be understandable with minimal background, and the submission should generally display empathy for people unfamiliar with the topic.</li>
<li><b>Motivation</b>: It should be clear to the reader/viewer within the first 30 seconds why they should care.</li>
<li><b>Novelty</b>: It doesn't necessarily have to be an original idea or original topic, but it should offer someone an experience they might otherwise not have by searching around online. Some of the greatest value comes from covering common topics in better ways. Other times there's value in surfacing otherwise obscure ideas which more people should know about.</li>
<li><b>Memorability</b>: Something should make the piece easy to remember even several months later. Maybe it's the beauty of the presentation, the enthusiasm of the presenter, or the mind-blowingness of an aha moment.</li>
</ol>

Also: please make sure it follows the 5 rules of the competition:

<ol>
<li>It has to be something new you make this summer</li>
<li>It has to be about math</li>
<li>One entry per person/group</li>
<li>It has to be available in English</li>
<li>It has to be publicly visible and available for people to consume for free</li>
</ol>


DISCLAIMER: All of the links provided here were generated by members of the SoME1 community and have not been pre-screened for any form of profane, sexist, racist, homophobic, or other behavior that may illicit negative reactions.
If you find anything that you feel is out-of-line, please contact me at jrs.schloss@gmail.com immediately.

'''.strip()

DEFAULT_EMAIL_SUBJECT = 'Welcome to the SoME1 Peer Review BETA!'

DEFAULT_EMAIL_BODY = '''
Hello {name}!

<p>
Thank you for agreeing to participate in the SoME1 peer review!

<p>
This is an essential part of the judging process and we ask everyone to seriously consider each entry provided and weigh their merits against each other.
We understand that this process is subjective, so please also use the <a href="https://docs.google.com/forms/d/e/1FAIpQLSc02JOlg0aAim5EukRlziSUdP59v40rgHizyW2PjNl-snfSTg/viewform?usp=sf_link">SoME1 Specific Feedback Form</a> whenever you feel it's necessary to provide more precise feedback.

<p>
We are expecting each judge to look at at least 5 entries and will be checking to make sure this is the case; however, there is no limit to the number of entries a single person may judge.
Each entry should take approximately 10 minutes to review, so we are expecting this to take less than an hour for each person.

<p>
For this, we will be using Gavel, an online expo judging system typically used for Hack-a-thons. This email contains your magic link to the judging system.

<p>
magic link to the judging system.

<p>
DO NOT SHARE this email with others, as it contains your personal magic link.

<p>
To access the system, visit <a href={link}>{link}</a>.

<p>
Once you're in, please take the time to read the welcome message and
instructions before continuing.

<p>
As an important note: we fully recognize that SoME1 is not a hack-a-thon.
This system will only be used to find the top 100 applicants.
Those applications will then be manually judged by Grant Sanderson, James Schloss, and other certified judges.

<p>
For more information about Gavel, please read either <a href="https://www.anishathalye.com/2015/03/07/designing-a-better-judging-system/">this</a> and <a href="https://www.anishathalye.com/2015/11/09/implementing-a-scalable-judging-system/">this</a> blog post.

<p>
For specific questions, please checkout out the <a href="https://github.com/leios/gavel/wiki/Frequently-Asked-Questions">FAQ</a> or <a href="https://discord.gg/Vkf29b5s">Discord</a>.
if you cannot find your answers there, please contact Dr. James Schloss at jrs.schloss@gmail.com

<p>
<b>Judging Criteria</b>

<p>
<b>Please look at at least 5 entries by Wednesday, September 1st!</b>

<p>
As discussed on the <a href="https://www.3blue1brown.com/blog/some1">SoME1 Website</a> please consider the following criteria when judging each entry:

<p>
<ol>
<li><b>Clarity</b>: Jargon should be explained, the goals of the lesson should be understandable with minimal background, and the submission should generally display empathy for people unfamiliar with the topic.</li>
<li><b>Motivation</b>: It should be clear to the reader/viewer within the first 30 seconds why they should care.</li>
<li><b>Novelty</b>: It doesn't necessarily have to be an original idea or original topic, but it should offer someone an experience they might otherwise not have by searching around online. Some of the greatest value comes from covering common topics in better ways. Other times there's value in surfacing otherwise obscure ideas which more people should know about.</li>
<li><b>Memorability</b>: Something should make the piece easy to remember even several months later. Maybe it's the beauty of the presentation, the enthusiasm of the presenter, or the mind-blowingness of an aha moment.</li>
</ol>

<p>
Also: please make sure it follows the 5 rules of the competition:

<p>
<ol>
<li>It has to be something new you make this summer</li>
<li>It has to be about math</li>
<li>One entry per person/group</li>
<li>It has to be available in English</li>
<li>It has to be publicly visible and available for people to consume for free</li>
</ol>

<p>
DISCLAIMER: All of the links provided here were generated by members of the SoME1 community and have not been pre-screened for any form of profane, sexist, racist, homophobic, or other behavior that may illicit negative reactions.
If you find anything that you feel is out-of-line, please contact me at jrs.schloss@gmail.com immediately.

<p>
Thanks again for both your submission and your willingness to review others.
We are excited to see all of the new, engaging math content everyone has made and hope you are too!

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
