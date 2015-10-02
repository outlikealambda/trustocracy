## Voting Mechanics

- Delegate
    - permanent (mvp)
    - votable specific (mvp)
    - per topic (v1)
- Vote
- Comment on Delegate (Testimonial?)
- Comment on Vote (Opinion?)

## Required Endpoints

#### Delegation

```
/delegate

{
    userId
    delegateId
    &votableId
    &comment
}
```

_Examples_

Follow a delegate; permanently and anonymously
```
{
    userId: "willsId",
    delegateId: "marksId"
}
```

Follow a delegate; permanently with testimonial
```
{
    userId: "willsId",
    delegateId: "marksId",
    comment: "Mark is a trustworthy guy"
}
```

Follow a delegate; for a single vote, anonymously
```
{
    userId: "willsId",
    delegateId: "marksId",
    votableId: "bill1982"
}
```

Follow a delegate; for a single vote, with testimonial
```
{
    userId: "willsId",
    delegateId: "tedsId",
    votableId: "billForFreeCoffee",
    comment: "Ted really knows his coffee!"
}
```

#### Voting

```
/vote

{
    userId
    votableId
    support
    comment
}
```
_Example_

Vote no with required Comment
```
{
    userId: "willsId",
    votableId: "bill2639",
    support: false
    comment: "In my opinion, ..."
}
```

### Not REST

- These are internal endpoints
- Optional parameters, like those for delegation, do not map well
