# Running Hasura On The Cheap
## What's Hasura?

Hasura is the company that created the [Hasura GraphQL Engine](https://github.com/hasura/graphql-engine#hasura-graphql-engine), a "blazing-fast GraphQL server that gives you instant, realtime GraphQL APIs over Postgres." (For this blog post, I may use "Hasura" and "Hasura GraphQL Engine" interchangeably because this post is about self-hosting their GraphQL engine. But Hasura the company offers more than just their GraphQL engine.)

![Hasura Landing Page](./images/hasura-landing.png)

You can use the Hasura GUI to create Postgres tables and easily do standard Postgres things like set:
* columns
* constraints
* primary/foreign/unique keys
* table relationships

![Table Relationships in Hasura](./images/hasura-table-relationships.png)

All this data is then accessible through a single GraphQL endpoint. You can use the integrated [GraphiQL IDE](https://github.com/graphql/graphiql#overview) to write queries, mutations, and subscriptions. 

![GraphiQL in Hasura](./images/graphiql.png)

Additionally, there are more advanced features like [permissioning](https://hasura.io/docs/latest/graphql/core/auth/authorization/permission-rules.html), [custom SQL functions](https://hasura.io/docs/latest/graphql/core/databases/postgres/schema/custom-functions.html), [event triggers](https://hasura.io/docs/latest/graphql/core/event-triggers/index.html). Beyond their documentation, many of these topics are covered in [their extremely handy tutorials](https://hasura.io/learn/).

I've been building [Trivia.Digital](https://trivia.digital) with Hasura as my backend, and it's made it very simple to configure my database and make my data accessible over a real-time GraphQL API. It's [open-source](https://hasura.io/opensource/) and has [great documentation](https://hasura.io/docs/latest/graphql/core/index.html) and I highly recommend it! As a relative noob to both Postgres and GraphQL, its UI is more beginner-friendly than a tool like [PostGraphile](https://www.graphile.org/postgraphile/).

The biggest _potential_ downside of Hasura is that it can be relatively expensive for a hobbyist to use it for a side project. But it doesn't have to be that way! Because their GraphQL Engine is open-source, I've been running it on [DigitalOcean](https://www.digitalocean.com/) for just $5/month.

**This post explains how you, too, can run Hasura for $5/ month while avoiding some potential pitfalls.** _Caveat_: I am not an expert on any of these topics, so my apologies if I've gotten anything wrong. If you have any suggestions, please email me at bhollander823@gmail.com.

Of course, this low bill is only possible because so many companies offer free plans for small projects. A _huge_ thank you to a bunch of other companies that have free plans.
<details>
  <summary>Expand this if you want to read more about the non-Hasura parts of my stack.</summary>
  </br>
  I'm using a 1-5 ⭐ system for how highly I recommend each tool, and I've included some information about their financial situation so you can get a better sense of how likely they are to stick around. Hasura gets five stars from me (and they
  <a href="https://hasura.io/blog/announcing-our-series-b-25m-financing/" target="_blank">raised a Series B in September 2020</a>).

  </br></br>

  ⭐⭐⭐⭐⭐ 
  * [Vercel](https://vercel.com/) – Vercel is a "deployment and collaboration platform for frontend developers." I'm hosting my frontend with them. They are the creators of the [Next.js React framework](https://nextjs.org/) and also maintain [Geist](https://github.com/geist-org/react), a minimal React UI library that I also use in my project. They last raised a [Series B round](https://vercel.com/blog/series-b-40m-to-build-the-next-web) in December 2020.
  * [GitHub](https://github.com/) – If you're reading this, you probably already know about GitHub. You can host your code on GitHub, open and review pull requests there, etc. Every deploy to my `main` branch on GitHub automatically triggers a new Vercel deploy. I'm most familiar with GitHub, but other people love [GitLab](https://about.gitlab.com/). They were [acquired by Microsoft in 2018](https://news.microsoft.com/announcement/microsoft-acquires-github/) for $7.5 billion.

  ⭐⭐⭐⭐
  * [Stream](https://getstream.io/) – Stream is a tool that makes it easier to build scalable in-app chat and activity feeds. I'm using it so everyone in a game can talk to each other over text chat. They [announced a Series B round](https://getstream.io/blog/stream-series-b-funding-announcement/) in March 2021 and shortly after released [a free plan for small businesses](https://getstream.io/maker-account/).
  * [Sentry](https://sentry.io/) – Sentry is an application monitoring platform so you can get alerted of any errors in your app. Dead simple to integrate through Vercel. They last raised [a Series D round](https://techcrunch.com/2021/02/18/app-monitoring-platform-sentry-gets-60-million-series-d-at-1-billion-valuation/) in February 2021. 
  * [Heap](https://heap.io/) – Heap is a product analytics tool that makes it easy to capture and understand your product usage data. They raised a [Series C round](https://heap.io/blog/company/our-55-million-series-c) in July 2019.
  * [Heroku](https://www.heroku.com/) – Heroku is a "cloud application platform" that makes it easy to deploy an app without spending too much time on infrastructure. I'm hosting my Postgres database with them. [Purchased by Salesforce](https://techcrunch.com/2010/12/08/breaking-salesforce-buys-heroku-for-212-million-in-cash/) in 2010.

  ⭐⭐⭐
  * [Jitsi](https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-iframe) – An open-source videochat platform. You can even run your videochats on their servers, for free! Less capable than some competitors (like Zoom, who now offer a [Video SDK](https://zoom.us/docs/en-us/video-sdk.html) that has a limited free plan) but incredible at the price point. Ownership has changed hands a bit, and was [last sold to 8×8 from Atlassian in 2018](http://social.techcrunch.com/2018/10/29/atlassian-sells-jitsi-an-open-source-videoconferencing-tool-it-acquired-in-2015-to-8x8/).
  * [Auth0](https://auth0.com/) – An authentication provider that makes it easy enough to let users securely sign in to your app. It's very nice to not worry too much about security, has its own login page I can redirect users to, and easily integrates with social login providers like Google. I don't love their login page, so I might replace them with my own auth system. Very recently (March 2021) [sold to Okta for $6.5 billion](https://auth0.com/blog/okta-auth0-announcement/).
</details>

## Self-Hosting Hasura GraphQL Engine on DigitalOcean ($5/month)

While the [free tier of Hasura Cloud](https://hasura.io/pricing/) is perfect for development, you are limited to 60 requests/minute. That's _probably_ not going to be enough for a production app. To get unlimited requests, you need to upgrade to the Standard tier which starts at $99/month. Because my site is more of a hobby project, I sought out a cheaper way to run my project in production.

Helpfully, Hasura has documentation on how to [easily deploy their GraphQL Engine](https://hasura.io/docs/latest/graphql/core/deployment/deployment-guides/digital-ocean-one-click.html) to [DigitalOcean](https://www.digitalocean.com/), where a virtual machine with 1 GB memory and 25 GB disk will run you $5/month. Seems like a good deal to me! 


## Hosting a Postgres Database on Heroku (free)

Hasura additionally has a guide to [creating a DigitalOcean managed Postgres database](https://hasura.io/docs/latest/graphql/core/deployment/deployment-guides/digital-ocean-one-click.html#using-digitalocean-managed-postgres-database). But those start at a comparatively steep $15/month.

Thankfully, it's incredibly easy to create a free database hosted on [Heroku](https://www.heroku.com/) when you create a new Hasura project. For the low price of $0/month, you can store up to 1 GB across 10,000 rows. For $9/month, your storage limit increases to 10 GB across ten million rows.

![Create Heroku Database](./images/create-heroku-database.png)

You might now be thinking, "If I'm going to host my database on Heroku, why don't I just host Hasura GraphQL Engine on Heroku too?" Well, the approximate Heroku equivalent of a [DigitalOcean Droplet](https://www.digitalocean.com/products/droplets/) is called a "[dyno](https://www.heroku.com/dynos)," and a dyno that doesn't auto-sleep starts at $7/month. So a dyno is generally a bit more expensive than the Droplet-equivalent. Still, Heroku is a "Platform as a Service" while DigitalOcean is "Infrastructure as a Service", so Heroku _does_ offer you additional features for your money if you choose to go that route.

## The Biggest Issue With These Hosting Choices

The biggest downside to this approach is that you must manually sync your Heroku database URL with your self-hosted Hasura GraphQL Engine. Before I implemented what I describe below, my site was unusable after Heroku maintenance.

### Why You Need This

There is own major downside to a free Heroku database: maintenance. After maintenance, **your database credentials change**. So, *you must* update your database credentials in your self-hosted Hasura GraphQL Engine so your app can continue to connect to your database.

<img src="./images/heroku-maintenance-email.png" alt="Heroku Maintenance Notice" width=300 />

Hasura Cloud offers "[Heroku URL Sync](https://hasura.io/docs/latest/graphql/cloud/projects/heroku-url-sync.html)" to keep your project's `HEROKU_DATABASE_URL` in sync. Unfortunately, this feature is only available for Hasura Cloud users. *Fortunately*, I'm about to tell you how to build this feature for your self-hosted Hasura GraphQL Engine.

### 1. Create a Webhook Server

[Webhooks](https://zapier.com/blog/what-are-webhooks/) are a way for apps to send automated messages to other apps. In this case, **we want Heroku to tell us when our database credentials change** so we can update them in our GraphQL Engine.

Adnan Hajdarević's open-source [webhook](https://github.com/adnanh/webhook#what-is-webhook-) tool makes it easy to spin-up a server that will receive event notifications over a webhook. Your Droplet is probably running Ubuntu 18+, so after [SSHing into your Droplet](https://docs.digitalocean.com/products/droplets/how-to/connect-with-ssh/), you can install `webhook` with the following command:

`sudo apt-get install webhook`

Once `webhook` is installed, you'll need to create a configuration file that defines the hooks that `webhook` will serve.

Here's what my `hooks.json` file looks like (except with correct paths, of course):

```
[
    {
        "id": "redeploy-webhook",
        "execute-command": "/path/to/redeploy.sh",
        "command-working-directory": "/path/to/folder/with/docker-compose.yaml"
    }
]
```

When the hook is called (we'll get to that in the next section!) it executes the `redeploy.sh` script in the directory with our `docker-compose.yaml` file. Note that we don't actually care about the payload – we only care about knowing that something has changed in our Heroku database and then running our script.

Our script will fetch the new database URL from Heroku and parse the database password from the URL. It'll then update our `.env` file with these new values. Finally, it will restart the Docker containers.

Here's what the `redeploy.sh` bash script looks like (make sure it's excecutable by running `chmod +x redeploy.sh`):

```
#!/bin/sh
URL=$(heroku config:get DATABASE_URL -a YOUR-HEROKU-APP-NAME)
PW=$(echo $URL | grep -Po "[a-zA-Z0-9]+?(?=@)")
echo "DATABASE_URI=$URL\nDATABASE_PASSWORD=$PW" > .env
docker-compose restart
```

Before this script will work, we need to install the Heroku CLI and authenticate ourselves. We can do this on Ubuntu with the following command:

`sudo snap install --classic heroku`

Then, run:

`heroku login -i`

and enter your login credentials. You'll also need to replace `YOUR-HEROKU-APP-NAME` in `redeploy.sh` with the name of the app that has the `Heroku Postgres` add-on installed. You can use the Heroku CLI to get a list of all your Heroku apps by running `heroku apps`.

Next, start the webhook server with the following command (be sure to replace `your-domain.com` with an address associated with the Droplet you've SSH'd into):

`webhook -hooks /path/to/hooks.json -ip "your-domain.com" -port 9003`

The hook is now available at http://your-domain.com:9003/hooks/redeploy-webhook

Note that I've chosen port 9003 arbitrarily – I cannot vouch for this port beyond that it functionally works for my application and it's not used by anything else. Also note that the webhook is using the insecure `http` protocol.

To upgrade to `https` you need to run the following command:

`webhook -hooks /path/to/hooks.json -secure -cert /path/to/public.crt -key path/to/private.key -ip "your-domain.com" -port 9003`

After running this command, your hook will be available at https://your-domain.com:9003/hooks/redeploy-webhook – much better!

If you've deployed the Hasura GraphQL Engine with [the app on the DigitalOcean Marketplace](https://marketplace.digitalocean.com/apps/hasura-graphql), one of it's dependencies – [Caddy](https://caddyserver.com/) – will automatically obtain and renew TLS certificates for you when you run `docker-compose up`. These certs are stored in a [Docker Volume](https://docs.docker.com/storage/volumes/), so you can peek in there to either copy them to a different directory _or_ provide a path to them. Do note that the `webhook` `-cert` flag expects a public key and the `-key` flag expects a private key. You can find [the full documentation on `webhook parameters` here](https://github.com/adnanh/webhook/blob/master/docs/Webhook-Parameters.md).

One last tip: when you run the above `webhook` command, add an ` &` to the end of it so the command runs in the background – you don't want the server to stop after you've closed your shell session.

### 2. Configure docker-compose.yaml to Use Environment Variables

This step should be refreshingly straightforward! Instead of directly setting `POSTGRES_PASSWORD` and `HASURA_GRAPHQL_DATABASE_URL` in `docker-compose.yaml`, have them read from environment variables. We already named these env vars in `redeploy.sh`, so you can reference them like so:

`POSTGRES_PASSWORD: "${DATABASE_PASSWORD}"`

and

`HASURA_GRAPHQL_DATABASE_URL: "${DATABASE_URI}"`

### 3. Tell Heroku About Your Webhook URL

Now, navigate to your Heroku app running your Postgres database. The URL will look something like https://dashboard.heroku.com/apps/YOUR-HEROKU-APP-NAME

Then, click `More` in the top-right and then `View webhooks`.

<img src="./images/create-heroku-webhook-1-of-2.png" alt="Create Heroku Webhook 1 of 2" width=190 />

On the new page, click `Create Webhook`. Enter in your URL from before – in this case, https://your-domain.com:9003/hooks/redeploy-webhook – and only select the `api:release` event type. If you'd like to set a secret, refer back to [the `webhook rules` documentation](https://github.com/adnanh/webhook/blob/master/docs/Hook-Rules.md).

<img src="./images/create-heroku-webhook-2-of-2.png" alt="Create Heroku Webhook 2 of 2" width=290 />

To test your setup, you can create a new config var in your Heroku app. Navigate to the `Settings` tab in your Heroku app, click `Reveal Config Vars` and create a new key. It doesn't matter what you put in as the key name – the point is to have Heroku hit your webhook by simulating a new release.

![Set Heroku Config Var](./images/heroku-set-config-var.png)

Hopefully, you're all set! You can double-check by navigating to the directory with your `docker-compose.yaml` file and seeing that the `.env` file matches your Heroku database credentials.

Now, any Heroku database maintenance will not be much of a problem for you or your app (though you'll likely have a few seconds of downtime while the credentials are updated).

## Conclusion

I hope you found this guide helpful! Again, if you have any suggestions or comments, please email me at bhollander823@gmail.com.

