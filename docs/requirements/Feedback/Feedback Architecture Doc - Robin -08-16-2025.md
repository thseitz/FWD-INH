1. You can also take a look at turborepo as another alternative to NX if you need it later.

2. Also if you’re doing async stuff you’ll probably want to think about either SSE or web sockets for sending updates to the client.

3. Keep in mind things like queue depth and message deletion/visibility timeout for SQS.

4. https://chatgpt.com/share/689cf023-8df0-8010-86bc-4d38f4a5a080

5. Also idempotent message handlers

6. And don’t keep long running transactions in Postgres. Configure the different Postgres timeouts so that a rogue transaction or statement times out rather than throttle the db

7. You might want to make the fields which can one of a set of strings seperate types or enums so you can reuse them. For example propertyUse in RealEstateAsset.

8. For your error object you’ll probably want to have some i8n logic on the front end which maps codes to error messages in different languages.

9. Make sure to disable the zustand dev middleware in prod builds:

https://github.com/pmndrs/zustand/discussions/842

10. In your useCreateAsset hook, your optimistic update isn’t actually optimistic. It just updates on success

11. Also personally I don’t really see the point of syncing data from react query to Zustand. You’re basically just storing the same data twice. Unless you want to mutate it in the front end in such a way that it diverges from the backend state.

12. I think the aws-amplify library will probably take care of token caching and lifetimes, auth redirects and so on for you.

13. You might want to see if you can add tenant id to your user token through a custom attribute in cognito rather than adding  extra database call to every request. Although I suppose you could also cache tenant ids, but adding it to the token seems easier
