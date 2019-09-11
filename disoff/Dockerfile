FROM crpd:latest
RUN apt-get update \
    && apt-get -y --no-install-recommends install ethtool

COPY disable-offload.sh /
RUN chmod a+rx disable-offload.sh
CMD ["/disable-offload.sh"]
