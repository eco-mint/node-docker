FROM tezos/tezos:master

# Install AWS CLI

USER root
RUN \
	apk -Uuv add groff less curl jq && \
	apk -Uuv add python3 py3-pip && \
	pip install six awscli

COPY ./start-tezos.sh /home/tezos/start-tezos.sh
RUN chmod 755 /home/tezos/start-tezos.sh

COPY ./utc-time-math.py /home/tezos/utc-time-math.py
RUN chmod 755 /home/tezos/utc-time-math.py

USER tezos
EXPOSE 8732 9732
ENTRYPOINT ["/home/tezos/start-tezos.sh"]
