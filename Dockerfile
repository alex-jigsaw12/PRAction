FROM ruby:2.7-alpine

LABEL "com.github.actions.name"="PRAction"
LABEL "com.github.actions.icon"="message-square"
LABEL "com.github.actions.color"="black"

RUN gem install octokit

ADD scr.sh /scr.sh
ENTRYPOINT ["/scr.sh"]