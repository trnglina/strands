# Strands

A minimal and unopinionated system for building narrative and dialogue DSLs in Lua.

```lua
-- examples/basic.lua
strands {
    ln, { [["Yes, of course, if it's fine tomorrow," said Mrs. Ramsay. ]],
    [["But you'll have to be up with the lark," she added.]] }, br,

    ln, { "To her son these words conveyed an extraordinary joy, as if it ",
    "were settled, the expedition were bound to take place, and the ",
    "wonder to which he had looked forward, for years and years it ",
    "seemed, was, after a night's darkness and a day's sail, within ",
    "touch." }, br,

    ln, { [["But," said his father, stopping in front of the drawing-room ]],
    [[window, "it won't be fine."]] }
}

-- examples/prompt.lua
strands {
    p("Hello there! Welcome to the world of POKEMON! My name is OAK! People ",
        "call me the POKEMON PROF! This world is inhabited by creatures ",
        "called POKEMON! For some people, POKEMON are pets. Others use them ",
        "for fights. Myself...I study POKEMON as a profession. First, what ",
        "is your name?"),

    prompt(set("player")),

    p("Right! So your name is ", get("player"), "! This is my grandson. He's ",
        "been your rival since you were a baby. ...Erm, what is his name ",
        "again? "),

    prompt(set("rival")),

    p("That's right! I remember now! His name is ", get("rival"), "! ",
        get("player"), "! Your very own POKEMON legend is about to unfold! A ",
        "world of dreams and adventures with POKEMON awaits! Let's go! "),
}
```
