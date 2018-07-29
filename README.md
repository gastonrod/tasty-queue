# TastyQ, match-making never tasted so good.

TastyQ or TastyQueue is a match-making bot for discord. It uses the [discordrb](https://github.com/meew0/discordrb) gem.

## The bot

You can add my bot on discord, its user is `TastyQ#0770`.

Currently it's being developed so most of the time the bot will be offline (until I consider it to be finished).

So far it only counts with Destiny 2 queues. They can be viewed in `config/queues_definition.yml`

### Its commands:
All commands must be pre-pended with `q!`. So far these are the implemented ones:

* `help`: gives this same list of commands.
* `join <queue_name>`: enlists you in the queue you specify.
* `leave <queue_name>`: removes you from the queue you specify
* `status`: tells you what users are signed up in the  queues you are enlisted in.
* `queues`: lists all the available queues.


## Usage

Install bundler, run `bundler install`.

Change the tokens used for the bot (I used `dotenv`'s gem).

I version ruby with ruby `rbenv` and use the `2.3.0-dev` version.

## TO-DO / Would be nice features to have

* Integration with Destiny 2's API to be able to match-make with mmr/item level.
* Multi-clan availability (so far it would lump everyone together in the same match-making system).
* Branch out to other games.
