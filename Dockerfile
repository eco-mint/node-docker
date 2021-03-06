FROM tezos/tezos:v13.0

# Install AWS CLI

USER root
RUN \
	apk -Uuv add groff less curl jq && \
	apk -Uuv add python3 py3-pip && \
	pip install six awscli

COPY ./start-tezos.sh /home/tezos/start-tezos.sh
RUN chmod 777 /home/tezos/start-tezos.sh

COPY ./utc-time-math.py /home/tezos/utc-time-math.py
RUN chmod 777 /home/tezos/utc-time-math.py

COPY ./config.json /home/tezos/config.json
RUN chmod 777 /home/tezos/config.json

USER tezos
EXPOSE 8732 9732
ENTRYPOINT ["/home/tezos/start-tezos.sh"]