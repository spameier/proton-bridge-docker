Run ProtonMail Bridge in a docker container

# Usage

## Starting the service

- initial setup
  ```
  docker volume create proton-bridge
  docker run --rm -v proton-bridge:/root -e PM_USER='<username>' -e PM_PASS='<password>' -e IMAP_PORT=143 -e SMTP_PORT=25 -p 25:25 -p 143:143 spameier/proton-bridge
  ```
- later execution
  ```
  docker run --rm -v proton-bridge:/root -e IMAP_PORT=143 -e SMTP_PORT=25 -p 25:25 -p 143:143 spameier/proton-bridge
  ```


## Configuring your email client

For credentials, use the "Username: <login>" and "Password: <passwd>"
that the service prints when it start.

The URL for the IMAP service is `localhost:143`, and the SMTP one is
`localhost:25`.

## Client compatibility

The ProtonMail Bridge officially supports Thunderbird only, but using
offlineimap or fetchmail works just fine. Here's an example
.fetchmailrc:

```
set daemon 15

defaults
  fetchall
#  keep

poll 127.0.0.1 service 2143 with protocol imap auth password
  user <login> there is seb here
  password <passwd>
```

# SSL certificates

## SMTP

Full certificate information:
```
echo | openssl s_client -connect localhost:2025 -starttls smtp | openssl x509 -noout -text
```

Fingerprints:
```
echo | openssl s_client -connect localhost:2025 -starttls smtp | openssl x509 -noout -fingerprint -md5
echo | openssl s_client -connect localhost:2025 -starttls smtp | openssl x509 -noout -fingerprint -sha1
echo | openssl s_client -connect localhost:2025 -starttls smtp | openssl x509 -noout -fingerprint -sha256
[...]
```

## IMAP

Full certificate information:
```
echo | openssl s_client -connect localhost:2143 -starttls imap | openssl x509 -noout -text
```

Fingerprints:
```
echo | openssl s_client -connect localhost:2143 -starttls imap | openssl x509 -noout -fingerprint -md5
echo | openssl s_client -connect localhost:2143 -starttls imap | openssl x509 -noout -fingerprint -sha1
echo | openssl s_client -connect localhost:2143 -starttls imap | openssl x509 -noout -fingerprint -sha256
[...]
```


# Credits

Thanks to Hendrik Meyer for socat+setcap workaround described at
https://gitlab.com/T4cC0re/protonmail-bridge-docker
