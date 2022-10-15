(define
    (domain day-planner)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__location)
        (maybe-know__location)
        (know__cuisine)
        (maybe-know__cuisine)
        (know__have_allergy)
        (have_allergy)
        (know__food_restriction)
        (know__budget)
        (know__outing_type)
        (maybe-know__outing_type)
        (know__conflict)
        (conflict)
        (know__restaurant)
        (know__outing)
        (know__goal)
        (goal)
        (have-message)
        (force-statement)
        (allow_single_slot_outing_type)
        (allow_single_slot_budget)
        (forcing__get-allergy)
    )
    (:action get-have-allergy
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (forcing__get-allergy))
                (not (know__have_allergy))
            )
        :effect
            (labeled-oneof         set-allergy
                (outcome indicate_allergy
                    (and
                        (know__have_allergy)
                        (have_allergy)
                        (forcing__get-allergy)
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (not (conflict))
                        (know__have_allergy)
                        (not (have_allergy))
                        (know__conflict)
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
                (know__have_allergy)
                (not (force-statement))
                (have_allergy)
            )
        :effect
            (labeled-oneof         set-allergy
                (outcome update_allergy
                    (and
                        (not (forcing__get-allergy))
                        (know__food_restriction)
                    )
                )
                (outcome fallback
                    (and
                        (not (forcing__get-allergy))
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action check-conflicts
        :parameters()
        :precondition
            (and
                (know__have_allergy)
                (know__cuisine)
                (not (know__conflict))
                (not (maybe-know__location))
                (not (maybe-know__cuisine))
                (know__location)
                (not (forcing__get-allergy))
                (know__food_restriction)
                (have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         check-conflicts
                (outcome restriction-dessert
                    (and
                        (conflict)
                        (know__conflict)
                    )
                )
                (outcome restriction-mexican
                    (and
                        (conflict)
                        (know__conflict)
                    )
                )
                (outcome no-restriction-1
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-2
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-3
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-4
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
            )
    )
    (:action reset-preferences
        :parameters()
        :precondition
            (and
                (conflict)
                (not (force-statement))
                (know__conflict)
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof         reset
                (outcome reset-values
                    (and
                        (not (know__food_restriction))
                        (not (know__conflict))
                        (force-statement)
                        (not (maybe-know__cuisine))
                        (not (know__cuisine))
                        (have-message)
                        (not (know__have_allergy))
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (know__conflict)
                (know__cuisine)
                (not (conflict))
                (not (maybe-know__cuisine))
                (not (know__restaurant))
                (not (forcing__get-allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         assign_restaurant
                (outcome set-mexican
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-italian
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-chinese
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-dessert
                    (and
                        (know__restaurant)
                    )
                )
            )
    )
    (:action set-outing
        :parameters()
        :precondition
            (and
                (know__outing_type)
                (not (forcing__get-allergy))
                (not (maybe-know__outing_type))
                (know__budget)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         assign_outing
                (outcome set-club
                    (and
                        (know__outing)
                    )
                )
                (outcome set-library
                    (and
                        (know__outing)
                    )
                )
                (outcome set-theater
                    (and
                        (know__outing)
                    )
                )
                (outcome set-golf
                    (and
                        (know__outing)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (know__restaurant)
                (know__outing)
                (not (forcing__get-allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         finish
                (outcome finish
                    (and
                        (know__goal)
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
            (labeled-oneof         reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
    (:action slot-fill__get-location
        :parameters()
        :precondition
            (and
                (not (know__location))
                (not (maybe-know__location))
                (not (forcing__get-allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome location_found
                    (and
                        (not (maybe-know__location))
                        (force-statement)
                        (have-message)
                        (know__location)
                    )
                )
                (outcome location_maybe-found
                    (and
                        (not (know__location))
                        (maybe-know__location)
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
    (:action clarify__location
        :parameters()
        :precondition
            (and
                (not (know__location))
                (not (force-statement))
                (maybe-know__location)
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof         validate-clarification
                (outcome confirm
                    (and
                        (not (maybe-know__location))
                        (know__location)
                    )
                )
                (outcome deny
                    (and
                        (not (know__location))
                        (not (maybe-know__location))
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
    (:action slot-fill__get-cuisine
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__cuisine))
                (not (maybe-know__cuisine))
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome cuisine_found
                    (and
                        (not (maybe-know__cuisine))
                        (know__cuisine)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome cuisine_maybe-found
                    (and
                        (not (know__cuisine))
                        (maybe-know__cuisine)
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
    (:action clarify__cuisine
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__cuisine))
                (maybe-know__cuisine)
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof         validate-clarification
                (outcome confirm
                    (and
                        (not (maybe-know__cuisine))
                        (know__cuisine)
                    )
                )
                (outcome deny
                    (and
                        (not (know__cuisine))
                        (not (maybe-know__cuisine))
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
    (:action slot-fill__get_outing
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__outing_type))
                (not (maybe-know__outing_type))
                (not (forcing__get-allergy))
                (not (know__budget))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome budget_found-outing_type_found
                    (and
                        (know__budget)
                        (know__outing_type)
                        (not (maybe-know__outing_type))
                    )
                )
                (outcome budget_found-outing_type_maybe-found
                    (and
                        (know__budget)
                        (maybe-know__outing_type)
                        (not (know__outing_type))
                    )
                )
                (outcome budget_found
                    (and
                        (know__budget)
                        (allow_single_slot_outing_type)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome outing_type_found
                    (and
                        (allow_single_slot_budget)
                        (force-statement)
                        (know__outing_type)
                        (not (maybe-know__outing_type))
                        (have-message)
                    )
                )
                (outcome outing_type_maybe-found
                    (and
                        (not (know__outing_type))
                        (maybe-know__outing_type)
                        (allow_single_slot_budget)
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
    (:action single_slot__outing_type
        :parameters()
        :precondition
            (and
                (allow_single_slot_outing_type)
                (not (know__outing_type))
                (not (maybe-know__outing_type))
                (not (forcing__get-allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome fill-slot
                    (and
                        (know__outing_type)
                        (not (allow_single_slot_outing_type))
                        (not (maybe-know__outing_type))
                    )
                )
                (outcome slot-unclear
                    (and
                        (not (know__outing_type))
                        (maybe-know__outing_type)
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
    (:action single_slot__budget
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__budget))
                (not (forcing__get-allergy))
                (allow_single_slot_budget)
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome fill-slot
                    (and
                        (know__budget)
                        (not (allow_single_slot_budget))
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
    (:action clarify__outing_type
        :parameters()
        :precondition
            (and
                (not (know__outing_type))
                (maybe-know__outing_type)
                (not (forcing__get-allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-clarification
                (outcome confirm
                    (and
                        (know__outing_type)
                        (not (maybe-know__outing_type))
                    )
                )
                (outcome deny
                    (and
                        (not (know__outing_type))
                        (not (maybe-know__outing_type))
                        (allow_single_slot_outing_type)
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
)