# syntax=docker/dockerfile:1

########## BUILD STAGE ##########
FROM golang:1.22-alpine AS builder
WORKDIR /src

# Dependências
RUN apk add --no-cache git ca-certificates

# Cache de deps
COPY go.mod go.sum ./
RUN go mod download


COPY . .

# Build estático
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /out/go-notes .

########## RUNTIME STAGE ##########
FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=builder /out/go-notes /app/go-notes
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/app/go-notes"]
