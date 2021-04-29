FROM node:10.16-stretch

LABEL vendor=Eva \
  com.evacenter.maintainer="Josué Ángeles <omar.josue@gmail.com>" \
  com.evacenter.product="Devops Challenge" \
  version="1.0" \
  description="Eva Devops Challenge"

RUN apt update -y && apt install -y libgl1-mesa-glx

ADD api/package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /runtime && cp -a /tmp/node_modules /runtime

WORKDIR /runtime

COPY api/package*.json ./
COPY api/*.js ./

COPY . /runtime

ENV BASE_URL="http://localhost:3000/"
ENV BASE_URL=$BASE_URL
ENV NODE_ENV="Development"
ENV NODE_ENV=$NODE_ENV

EXPOSE 3000
CMD npm run start