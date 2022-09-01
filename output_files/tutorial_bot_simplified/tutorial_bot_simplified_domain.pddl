(define
    (domain day-planner)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_cuisine)
        (have_restaurant)
        (have_have_allergy)
        (have_allergy)
        (have_food_restriction)
        (have_conflict)
        (conflict)
        (have_low_budget)
        (low_budget)
        (have_outing_atmosphere)
        (have_goal)
        (goal)
        (have-message)
        (force-statement)
        (food_restriction-value-dairy-free)
        (food_restriction-value-gluten-free)
        (cuisine-value-mexican)
        (cuisine-value-italian)
        (cuisine-value-chinese)
        (cuisine-value-dessert)
    )
    (:action get-cuisine
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (have_cuisine))
            )
        :effect
            (labeled-oneof set-cuisine
                (outcome valid
                    (and
                        (have_cuisine)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action get-have-allergy
        :parameters()
        :precondition
            (and
                (not (have_have_allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof set-allergy
                (outcome indicate_allergy
                    (and
                        (have_have_allergy)
                        (have_allergy)
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (not (have_allergy))
                        (have_conflict)
                        (have_have_allergy)
                        (not (conflict))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action get-allergy
        :parameters()
        :precondition
            (and
                (have_have_allergy)
                (have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof set-allergy
                (outcome update_allergy
                    (and
                        (have_food_restriction)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action reset-preferences
        :parameters()
        :precondition
            (and
                (conflict)
                (have_conflict)
                (not (force-statement))
            )
        :effect
            (labeled-oneof reset
                (outcome reset-values
                    (and
                        (force-statement)
                        (have-message)
                        (not (have_food_restriction))
                        (not (have_have_allergy))
                        (not (have_conflict))
                        (not (have_cuisine))
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (have_cuisine)
                (not (force-statement))
                (not (have_restaurant))
                (not (conflict))
                (have_conflict)
            )
        :effect
            (labeled-oneof assign_restaurant
                (outcome set-mexican
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-italian
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-chinese
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-dessert
                    (and
                        (have_restaurant)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (have_restaurant)
                (not (force-statement))
            )
        :effect
            (labeled-oneof finish
                (outcome finish
                    (and
                        (have_goal)
                        (goal)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (force-statement)
                (have-message)
            )
        :effect
            (labeled-oneof reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action check-conflict-1-or-1
        :parameters()
        :precondition
            (and
                (have_have_allergy)
                (not (force-statement))
                (food_restriction-value-gluten-free)
                (cuisine-value-mexican)
                (have_allergy)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (conflict)
                        (have_conflict)
                    )
                )
            )
    )
    (:action check-conflict-1-or-2
        :parameters()
        :precondition
            (and
                (have_have_allergy)
                (not (force-statement))
                (food_restriction-value-dairy-free)
                (have_allergy)
                (cuisine-value-dessert)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (conflict)
                        (have_conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-1
        :parameters()
        :precondition
            (and
                (cuisine-value-italian)
                (have_have_allergy)
                (not (force-statement))
                (have_food_restriction)
                (have_allergy)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (have_conflict)
                        (not (conflict))
                    )
                )
            )
    )
    (:action check-conflict-2-or-2
        :parameters()
        :precondition
            (and
                (have_have_allergy)
                (cuisine-value-chinese)
                (not (force-statement))
                (have_food_restriction)
                (have_allergy)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (have_conflict)
                        (not (conflict))
                    )
                )
            )
    )
    (:action check-conflict-2-or-3
        :parameters()
        :precondition
            (and
                (have_have_allergy)
                (not (force-statement))
                (food_restriction-value-dairy-free)
                (cuisine-value-mexican)
                (have_allergy)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (have_conflict)
                        (not (conflict))
                    )
                )
            )
    )
    (:action check-conflict-2-or-4
        :parameters()
        :precondition
            (and
                (have_have_allergy)
                (not (force-statement))
                (food_restriction-value-gluten-free)
                (have_allergy)
                (cuisine-value-dessert)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (have_conflict)
                        (not (conflict))
                    )
                )
            )
    )
    (:action set-food_restriction
        :parameters()
        :precondition
            (and
                (not (food_restriction-value-gluten-free))
                (not (food_restriction-value-dairy-free))
                (have_food_restriction)
            )
        :effect
            (labeled-oneof set-valid-value
                (outcome dairy-free
                    (and
                        (food_restriction-value-dairy-free)
                    )
                )
                (outcome gluten-free
                    (and
                        (food_restriction-value-gluten-free)
                    )
                )
            )
    )
    (:action set-cuisine
        :parameters()
        :precondition
            (and
                (not (cuisine-value-mexican))
                (not (cuisine-value-chinese))
                (have_cuisine)
                (not (cuisine-value-italian))
                (not (cuisine-value-dessert))
            )
        :effect
            (labeled-oneof set-valid-value
                (outcome mexican
                    (and
                        (cuisine-value-mexican)
                    )
                )
                (outcome italian
                    (and
                        (cuisine-value-italian)
                    )
                )
                (outcome chinese
                    (and
                        (cuisine-value-chinese)
                    )
                )
                (outcome dessert
                    (and
                        (cuisine-value-dessert)
                    )
                )
            )
    )
)