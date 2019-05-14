# What is a Distributed System?

While working on [my primary project][terribledb] at [the Recurse Center][rc],
I have answered the question of "what are you working on" on a near-daily
basis. This is my attempt to lay a foundation to understand what I mean when I
talk "Distributed Systems".

Many applications these days (TK links) claim to be or support distributed
systems. I'm going to refer to the term to more closely resemble academia's
use.

## Process Model

A distributed system is a model that can be applied to any artifact in the real
world. In the distributed system model, independant **Processes** perform
computations concurrently. They are independant because the only way they can
interact with each other is by sending and receiving messages over a network.

Processes can send messages to and receive messages from each other over a
network. Typically networks are broadly categorized as **reliable** or
**unreliable**. This usually maps to a number of different characteristics of
the send and receive command.

## Network

In an unreliable network, a message may only be delivered after it is sent.
However, a message may also be delivered extremely late. It may be delivered
after messages that were sent later. It may be delivered multiple times, or
never. Crucially, a sender does not know whether or not the message it sent was
received. The internet's series of Wireless and Wired connections constitutes a
fundamentally unreliable network.

In a reliable network, usually the guarantee is given that a message sent will
be received precisely once, and in a timely manner. It may further be
guaranteed that those messages will always arrive in the order that they are
sent.

There exist many protocols (and protocol stacks), through which we can define
we can emulate the behavior of a mostly-reliable network over a fundamentally
unreliable network.

## State

A common additional constraint is: All processes within a system are executing
the same code. Processes maintain the state needed to proceed with computation.
Processes may also crash, and be restarted or not. Sometimes, restarted
processes may be able to access state that was stored before it crashed. That
state is labeled **persistent**.

## Applications

Human beings form a process model. Gossip communication (between people)
spreads in a similar way. Two people waving to each other in greeting is
fundamentally the same as a TCP handshake.

In the same way that we have managed to build (seemingly) reliable networks out
of faulty network components, it is my goal with distributed systems to build
reliable processes out of fault ones.


[rc]: https://www.recurse.com "Recurse Center"
[terribledb]: https://github.com/shantiii/terribledb "TerribleDB"
