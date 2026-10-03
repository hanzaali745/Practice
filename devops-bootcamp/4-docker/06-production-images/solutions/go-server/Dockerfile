# Lab 2 — multi-stage build: a builder of hundreds of MB → a ~2 MB final image

# ---- stage 1: build a static binary ----
FROM golang:1.23 AS build
WORKDIR /src
COPY main.go .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /out/server main.go

# ---- stage 2: copy ONLY the binary into a minimal, non-root image ----
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/server /server
USER nonroot
EXPOSE 8080
ENTRYPOINT ["/server"]
