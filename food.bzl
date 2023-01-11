EaterInfo = provider("", fields = ["food"])

def _make_food(ctx):
    food_files = [eater[EaterInfo].food for eater in ctx.attr.srcs]
    combined_output_file = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.run_shell(
        outputs = [combined_output_file],
        inputs = food_files,
        command = "cat $@ > {}".format(combined_output_file.path),
        arguments = [file.path for file in food_files],
    )

    return DefaultInfo(files = depset(food_files + [combined_output_file]))

make_food = rule(
    _make_food,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            providers = [EaterInfo],
        ),
    },
)

def _make_eater(ctx):
    food_file = ctx.actions.declare_file("food")
    ctx.actions.write(food_file, "{}\n".format(ctx.attr.food))

    eater_file = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.write(eater_file, "", is_executable=True)

    return [
        EaterInfo(
            food = food_file,
        ),
        DefaultInfo(
            executable = eater_file,
            files = depset([eater_file]),
            runfiles = ctx.runfiles([food_file]),
        )
    ]

make_eater = rule(
    _make_eater,
    attrs = {
        "food": attr.string(mandatory = True),
    }
)
