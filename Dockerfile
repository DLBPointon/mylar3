FROM python:3.11-alpine3.23

ARG BUILD_COMMIT=unknown
LABEL org.opencontainers.image.revision=$BUILD_COMMIT

RUN \
echo "**** install system packages ****" && \
 apk add --no-cache \
 git \
 # cfscrape dependencies
 nodejs \
 # unrar-cffi & Pillow dependencies
 build-base \
 # unar-cffi dependencies
 libffi-dev \
 # Pillow dependencies
 zlib-dev \
 jpeg-dev

# It might be better to check out release tags than nightly HEAD.
# For development work I reccomend mounting a full git repo from the
# docker host over /app/mylar.
RUN echo "**** install app ****" && \
 git config --global advice.detachedHead false && \
 git clone https://github.com/DLBPointon/mylar3.git --depth 1 --branch token_update --single-branch /app/mylar

RUN echo "**** install requirements ****" && \
 pip3 install --no-cache-dir -U -r /app/mylar/requirements.txt && \
 rm -rf ~/.cache/pip/*

# TODO image could be further slimmed by moving python wheel building into a
# build image and copying the results to the final image.

# ports and volumes
VOLUME /config /comics /downloads
EXPOSE 8090
CMD ["python3", "/app/mylar/Mylar.py", "--nolaunch", "--quiet", "--datadir", "/config/mylar"]
