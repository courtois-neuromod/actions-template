
def expr_to_opts(expr):
    opts = []
    if not expr:
        return []
    expr = expr.replace('(', ' ( ').replace(')', ' ) ')
    for sub_expr in expr.split(' '):
        if len(sub_expr):
            if sub_expr in '()':
                opts.append(f"-{sub_expr}")
            else:
                opts.append(f"--{sub_expr}")
    return opts
