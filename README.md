# Space Quiz

A single-file space trivia quiz — open `index.html` in a browser and play ten questions. No build step, no dependencies.

## Devin

`devin.sh` is a small helper for calling the Devin API. `jq` and `curl` are required.

Export your credentials first:

```bash
export DEVIN_API_KEY=cog_...
export DEVIN_ORG_ID=...
```

Then run one of:

```bash
./devin.sh create "prompt"              # start a new Devin session
./devin.sh list                         # list sessions
./devin.sh msg SESSION_ID "message"     # send a message to a session
./devin.sh note                         # create the Space Quiz knowledge note
```
