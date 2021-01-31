package play

default hello = false

hello {
    m := input.message
    m == "world"
}

newdata = msg {
    msg := concat("", ["Received the message: ", input.message])
}

importdata = msg {
	msg := concat("", ["Received the static data: ", data.rule])
}