## Votable Status

- Votable Source
    - bill text? (mvp)
    - bill state? (mvp)
- Current vote-opinions (mvp)
- Popular public-delegates (mvp)
- Result Distribution
    - Delta history (v1)

Endpoints

Source
```
[GET]/votable/[votableId]/source

{
    text: "end eyebrow discrimination",
    state: "floored"
}
```

Vote-Opinions
```
[GET]/votable/[votableId]/opinions?limit=2&offset=6
[
    {
        vote: yes,
        opinion: "It's so not fair!"
    },
    {
        vote: no,
        opinion: "This is definitely not a real things"
    }
]
```

Popular public-delegates

```
[GET]/votable/[votableId]/delegates?limit=2&offset=8
[
    {
        // delegated vote
        name: "Sharon Matsuyama",
        influence: 118,
        isDelegated: true,
        &delegateId: "marksId",
        &vote: null,
        comment: "Well written analysis of eyebrows"
    },
    {
        // direct vote
        name: "Adele Lee",
        influence: 68,
        isDelegated: false,
        &delegateId: null,
        &vote: no,
        comment: "Still not a real thing"
    }
]
```

Distribution
```
[GET]/votable/[votableId]/balance
[
    {
        vote: yes,
        support: 19
    },
    {
        vote: no,
        support: 228
    },
    {
        vote: abstain,
        support: 3
    }
]
```
