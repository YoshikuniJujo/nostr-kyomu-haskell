FROM gentoo/stage3:latest

RUN emerge --sync
RUN emerge -v curl
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
RUN . /root/.ghcup/env
ENV PATH /root/.ghcup/bin:$PATH

RUN ghcup install ghc 9.14.1
RUN ghcup install ghc 9.10.3
RUN ghcup install cabal 3.16.1.0
RUN ghcup install stack 3.9.1

COPY nostr-kyomu-haskell /opt/nostr-kyomu-haskell
WORKDIR "/opt/nostr-kyomu-haskell"
RUN stack build

CMD ["stack", "exec", "nostr-kyomu-haskell-exe"]
