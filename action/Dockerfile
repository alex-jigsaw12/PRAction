FROM ruby:2.7-alpine

LABEL "com.github.actions.name"="PRComment"
LABEL "com.github.actions.icon"="message-square"
LABEL "com.github.actions.color"="black"

RUN gem install octokit

ADD entrypoint.sh /scr.sh
ENTRYPOINT ["/scr.sh"]