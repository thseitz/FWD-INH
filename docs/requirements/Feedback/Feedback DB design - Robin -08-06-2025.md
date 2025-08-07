1. Why are you storing passwords/dealing with users yourself rather than have cognito or some other auth service take care of it for you?

2. I’ve never worked with cognito specifically, but usually with these auth services they take care of managing login, user passwords, email validation, social logins, MFA, SCIM etc. and they just send you an auth token with the user id and some additional user info you can configure.

3. Just curious cause I see you have a user table with password_hash and email validation fields and stuff. Some auth services also take care of multi tenancy.

4. Yeah, they can be kind of a PITA to configure though. We use propel auth which is a startup, the nice thing about them is it’s super easy to get up and running, but they’re not as feature complete as some of the big players

5. Also I’m not sure if you want to limit file names to 255 chars or not, that seems kind of limiting. Maybe rethink some of your varchar limits, and use text instead if there’s no reason to limit them. 

https://chatgpt.com/share/6893a524-77b8-8010-a501-0884f11141c4

6. There’s no real benefit to having varchar(n) over text unless there’s a business/data use case for limiting the length

7. For example it makes sense for the color codes cause they’ll always be Rgba hex values. You could actually also store them as integers if you wanted to save some space but probably not worth he hassle

8. Check constraints, indexes, and triggers are fine but keep in mind they’ll slow down writes so avoid using on write heavy tables. I doubt you’re going to have problems with any of them initially and you can always remove them later. For super right heavy tables you can use unlogged tables, as long as the data in them isn’t critical (they don’t get written to the WAL)

9. Usually it’s a good idea for most of your tables to have created_at, updated_at, created_by and updated_by fields. All of them aren’t always relevant (for example in many to many tables rows don’t usually get updated)

10. Be careful with email regexes, they’re notoriously hard to get accurate due to all the different forms a valid email can take. I’ve seen a poorly written email regex with no specified timeout take down a production server

11. Also: keep in mind Postgres doesn’t create indexes automatically for foreign key relationships like some dbs so you’ll have to create them yourself if you want them

12. Wherever you have columns that are arrays of keys into other tables: e.g. rules_applied in pii_processing_job - you won’t be able to create a foreign key for an array. Which might be fine, but it does leave it up to the application to enforce that if a rule is deleted it takes the appropriate action with the places the rule is referenced in the array

13. Also: store all your Time data in the db in UTC, let the front end translate to local time

14. So rather than DEFAULT NOW() do DEFAULT (NOW() AT TIMEZONE ‘utc’))

15. Just in general work in UTC and only convert when you need to display it

16. Think you’re missing row level security rules in your sql, unless I missed it

17. I’m not sure it’s a good idea to set the connection limit to -1 when you create the db. I think leaving it at the default (100 iirc) is better. And then if you need more connections put a proxy in front of it

18. Nice looks good. I think some devs might say that a lot of the check constraints should be enforced in the application not the database (or at least in the application and the database). They might also say that having a bunch of stuff in stored procs will make it harder to switch databases in the future, although I don’t know if this is that valid of an argument as Postgres scales reasonably well and you can shard it now with things like Citus. Realistically moving from sql to nosql is usually a big shift either way and people tend not to really switch sql databases

19. Oh also, you might look into nest.js

20. Also if you’re using elasticache to back your background jobs (e.g. bull) be a little careful cause it can get pretty expensive pretty quickly. Thats why I like Postgres backed work queues, cause you can just use your db and you don’t have to pay for a seperate service. Then you can always move to something else later

21. We used river for golang:

https://riverqueue.com/docs

22. But I’m sure there’s a good one for js out there as well

23. If you do still want to go with elasticache don’t start with the serverless option. Looks like it’s going to be quite a bit more expensive at smaller scale. Also you might consider skipping the background job thing entirely and go straight for a workflow orchestrator. It sounds like you might have a lot of “if x happens do y otherwise do z” kind of workflows which kind of suck to try to hack into a job queue yourself.

