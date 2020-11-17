FROM ubuntu:20.04
ENV HOME /
ENV TOOL_OUT /out
RUN apt update --fix-missing \
    && apt -y install git python3-dev python3-pip \
    && apt clean

ENV LC_ALL "C.UTF-8"
ENV LANG "C.UTF-8"

WORKDIR ${HOME}
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN git clone https://github.com/lanmaster53/recon-ng \
    && ln -s /recon-ng/recon /recon \
    && ln -s /recon-ng/VERSION /VERSION
RUN git clone https://github.com/infosec-au/altdns

RUN python3 -m pip install -r /recon-ng/REQUIREMENTS
RUN python3 -m pip install /altdns/

ADD words.txt /words.txt
ADD enumall.py /enumall.py

RUN chmod +x /enumall.py
RUN mkdir -p /${TOOL_OUT} && chmod -R 700 /${TOOL_OUT}
ENTRYPOINT ["/enumall.py"]
