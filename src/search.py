import typing

import board

INFINITY: int = 1 << 31


def negamax(b: board.Board, e: typing.Callable, d: int, c: int) \
        -> (int, typing.List[int]):
    """
    implementation of negamax search algorithm.
    :param b: board to search
    :param e: evaluation function
    :param d: depth to search to
    :param c: perspective to search by
    :return: (score, best moves, nodes)
    """

    if not d or b.is_game_over():
        return e(b) * c, [], 1

    score: int = -INFINITY
    best_move: int = 0
    nodes: int = 0
    for move in board.split_bitboard(b.get_legal_moves()):
        b.make_move(move)
        child_score, child_pv, child_nodes = negamax(b, e, d - 1, -c)
        b.undo_move()

        nodes += child_nodes
        child_score *= -1

        if child_score > score:
            score = child_score
            best_move = move
            pv = child_pv

    return score, [best_move] + pv, nodes