import random


def get_cool_random_number():
    """Returns a cool random number. Cool mostly refers to nerdy here."""
    return random.choice([42, 1337, 4711, 0xBADDCAFE])


def is_number_cool(number: int):
    """Returns True if the given number is cool. Returns False otherwise."""
    for i in range(20):
        if number == get_cool_random_number():
            return True
    return False
