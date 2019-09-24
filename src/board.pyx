# cython: language_level=3

"""
file: board.py

description: contains code for board representation and move generation.
"""

ctypedef unsigned long long bitboard

# set utility constants
cdef int YELLOW = 0
cdef int RED = 1

cdef bitboard ONE = 1

# the board will be represented with a 7x7 bitboard with the bottom as a
# placeholder/helper for move generation. the representation will be from
# bottom left (msb) to top right (lsb).
cdef bitboard EMPTY_BOARD = sum(
    1 << i
    for i, x in enumerate(0 if i % 7 else 1 for i in range(49))
    if x
)

# define bit list (list of all bits)
cdef list BIT_LIST = [ONE << i for i in range(49)]

# directions for shifting the bitboard representation.
cdef int UP = 1
cdef int RIGHT = 7
cdef int DOWN = -UP
cdef int LEFT = -RIGHT

cdef int UP_RIGHT = UP + RIGHT
cdef int UP_LEFT = UP + LEFT
cdef int DOWN_RIGHT = DOWN + RIGHT
cdef int DOWN_LEFT = DOWN + LEFT


# define utility functions here.
cdef int popcount(bitboard b):
    """
    counts the number of bits in bitboard `b`.
    :param b: bitboard to count
    :return: number of bits
    """

    cdef int n = 0
    while b:
        b &= b - 1
        n += 1
    return n


cdef bitboard shift(bitboard b, d: int):
    """
    returns a copy of the bitboard `b` after shifting by direction `d`.
    :param b: the bitboard to shift
    :param d: direction to shift the bitboard
    :return: copy of shifted bitboard
    """

    return b << d


cpdef split_bitboard(bitboard b):
    """
    returns a list of the possible moves from the given bitboards.
    :param b: bitboard to break down into individual moves.
    :return: list of all moves
    """

    cdef list moves = []
    cdef bitboard bit, x
    for bit in BIT_LIST:
        x = b & bit
        if x:
            moves.append(x)

    return moves


# main class for board representation.
cdef class Board(object):
    cdef public bitboard yellow_bitboard, red_bitboard
    cdef public int turn
    cdef readonly list past_moves

    def __init__(self, bitboard ybb = 0, bitboard rbb = 0, int t = YELLOW):
        """
        wrapper class for the bitboard board representation. contains multiple
        utility methods for easy utilisation of the board.
        :param ybb: bitboard for yellow pieces
        :param rbb: bitboard for red pieces
        :param t: turn indicator
        """

        # piece bitboards for both players. the yellow player goes first.
        self.yellow_bitboard = ybb
        self.red_bitboard = rbb

        self.turn = t
        self.past_moves = []

    def __copy__(self):
        return Board(self.yellow_bitboard, self.red_bitboard, self.turn)

    def __deepcopy__(self):
        return self.__copy__()

    cpdef bitboard get_legal_moves(self):
        """
        generates all legal moves from the current board position.
        :return: bitboard representation of all legal moves
        """

        cdef bitboard pieces = self.yellow_bitboard | self.red_bitboard | EMPTY_BOARD
        return shift(pieces, UP) & (~pieces)

    cpdef void make_move(self, bitboard m):
        """
        makes a move on the current game position.
        :param m: bitboard representation of the move.
        :return: None
        """

        self.past_moves.append(m)

        if self.turn == YELLOW:
            self.yellow_bitboard += m
            self.turn = RED
        else:
            self.red_bitboard += m
            self.turn = YELLOW

    cpdef void undo_move(self):
        """
        undoes a move from the current game state.
        :return: None
        """

        if self.turn == YELLOW:
            self.red_bitboard -= self.past_moves.pop()
            self.turn = RED
        else:
            self.yellow_bitboard -= self.past_moves.pop()
            self.turn = YELLOW


if __name__ == "__main__":
    board = Board()
    print(tuple(
        split_bitboard(board.get_legal_moves())
    ))
