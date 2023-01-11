def _make_food(ctx):
    combined_output = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.run_shell(
        outputs = [combined_output],
        inputs = ctx.files.srcs,
        command = "cat $@ > {}".format(combined_output.path),
        arguments = [file.path for file in ctx.files.srcs],
    )

    return DefaultInfo(files = depset(ctx.files.srcs + [combined_output]))

make_food = rule(
    _make_food,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
    },
)
