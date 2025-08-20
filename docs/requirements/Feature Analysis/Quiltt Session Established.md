Short version: the Quiltt “session token” is not a permanent data key.
It’s a short-lived, profile-scoped token your Nest backend issues to your React app to (a) launch Connector and/or (b) make user-scoped GraphQL calls. After the user links their bank, Quiltt creates a Connection tied to that Profile. Ongoing data access uses the Profile/Connection—not the same one-time session token—via normal API auth from your backend. 


Here’s the practical breakdown:

1) During linking (client)

Your Nest server creates a Session token (server-side POST to Quiltt Auth).
The token is scoped to a single Profile and is safe to hand to the browser. You pass it to the React app to start Connector. 


2) After linking completes

Quiltt now has a Connection for that Profile and begins syncing permissioned data (accounts, balances, transactions, etc.). You don’t receive bank creds; you just get IDs (profileId/connectionId) to reference later. 
Quiltt Docs

3) How you access/update data later (server)

You generally do this server-to-server from Nest using one of these auth methods:

Profile GraphQL API (server):
Use Basic Auth = Base64(profileId:API_KEY_SECRET). Good for fetching that user’s data on your cron jobs or webhook handlers. 

Platform/REST API (server):
Use your Environment API key as a Bearer token for environment-scoped tasks (issuing sessions, managing profiles, etc.). Never expose this in the browser. 

You can also use a fresh Session token for user-scoped GraphQL calls (e.g., from your client or short server tasks), and you can check/revoke those tokens via the Auth API. But don’t treat them as long-term keys. 


4) Staying in sync

Subscribe to webhooks (HMAC-signed) and on events like “connection synced” pull new data via your server auth (Basic or Bearer, as above). Be sure to verify the HMAC signature and use the raw body in Nest. 


TL;DR flow you’ll implement

1. Nest issues Session token → React launches Connector. 

2. Connector finishes → Quiltt creates/updates Connection for that Profile. 

3. Nest (cron or webhook) fetches data using Basic (profileId: API_KEY_SECRET) for GraphQL, or Bearer API key for Platform endpoints. 


===========================================================================================

okay how do I find the right profile for my client if I have a general quiltt login key 
ChatGPT said:
Thought for 16s

Great question. Think of Quiltt as giving you two identifiers you can use:

Your own external ID (UUID) that you pass when you create/authenticate a profile

Quiltt’s profile ID (userId) that Quiltt returns

The reliable pattern (do this)

When issuing a Session token, pass your user’s internal ID as userId (if you already have a Quiltt profile) or as userUUID/userId when creating a new one. Quiltt will either look up or create the Profile and return its userId. Persist both in your DB (yourUserId ⇄ quilttUserId). The docs explicitly call out “Make sure to persist the userId.” 


Going forward, look up the Quiltt profile by your own user’s ID in your DB and use that stored quilttUserId (profile ID) for API access (GraphQL via Basic Auth or new Session tokens). 


If you already have users and only your environment API key

Use the Platform API (server-to-server, Bearer with your env API key) to retrieve Profiles in your environment, then map them by attributes you set (email/phone/metadata) if you didn’t store the IDs earlier. Practically: call the Platform API to list/get Profiles, but long-term you should still persist the mapping. 


Minimal flows

A) New user → create or fetch Profile and remember it

Nest (server) → POST https://auth.quiltt.io/v1/users/sessions (Bearer: your API key)

Include your own UUID/email/phone so you can recognize them later.

Quiltt responds with token and userId (the Profile ID) → store it. 


B) Existing user → get their Profile to query data

Look up quilttUserId from your DB (set in A).

Use Basic Auth to GraphQL: Base64(profileId:API_KEY_SECRET) for server pulls/webhooks/cron. Or issue a fresh Session token if you need client-side GraphQL/Connector. 


Safety net: webhooks to backfill mappings

Subscribe to Profile / Connection events and, on receipt, upsert the mapping (yourUserId, quilttUserId, connectionId) based on the context you have at linking time. 


TL;DR

Best practice: When you create/auth a profile, pass your own ID and persist Quiltt’s userId. Use that stored userId forever after. 


If you only have the environment key right now: query via the Platform API, match by attributes you provided (email/phone/metadata), then store the mapping so you never have to scan again. 
