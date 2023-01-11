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
    return [
        EaterInfo(food = ctx.file.food),
    ]

make_eater = rule(
    _make_eater,
    attrs = {
        "food": attr.label(mandatory = True, allow_single_file = True),
    },
)

def _eater_repository(rctx):
    rctx.file("WORKSPACE")
    rctx.file("BUILD", """
load("@root//:food.bzl", "make_eater")

make_eater(
    name = "mouth",
    food = "food",
    visibility = ["//visibility:public"],
)
    """)

    rctx.file("food", "{}\n".format(rctx.attr.food))

eater_repository = repository_rule(
    _eater_repository,
    attrs = {
        "food": attr.string(mandatory = True),
    },
)
