using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Test : MonoBehaviour
{
    private RectTransform _rectTransform;

    void Start()
    {
        _rectTransform = GetComponent<RectTransform>();
        Debug.Log(_rectTransform.position);
        Debug.Log(_rectTransform.localPosition);
        Debug.Log(transform.localPosition);
        Debug.Log(transform.position);
        IAnimal dog = new Dog();
        IAnimal cat = new Cat();
        CheckType(dog);
    }

    void CheckType(IAnimal animal)
    {
        if (animal is Dog)
        {
            var dog = animal as Dog?;
            Debug.Log(animal == (IAnimal)dog);
        }
        
        if (animal is Cat)
        {
            
        }
    }
}

public interface IAnimal
{
    
}

public struct Dog : IAnimal
{
}

public struct Cat : IAnimal
{
}